class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index #worry about this
  
    # declarations
    @movies = Movie.all
    @all_ratings = Movie.get_ratings
    redirect_args = Hash.new
    
    # which ones to pay attention to
    @param_ratings = @all_ratings.select do |rating|
        params["rating_"+rating]
      end
    if not @param_ratings.empty?
      @all_ratings.each do |rating|
        session["rating_"+rating] = params["rating_"+rating]
      end
    else 
      to_redirect = true
    end
    
    # checkbox stuff
    @picked = @all_ratings.select do |rating|
      session["rating_"+rating]
    end
    
    # use redirect var to keep track of ratings when we hit the back button
    if(@picked.empty?)
      to_redirect = true
      @picked = @all_ratings
    end
    
    @picked.each do |rating|
      redirect_args["rating_"+rating] = true
    end
    
    # append the redirection to the uri
    if to_redirect
      redirect_to movies_path(redirect_args)
    else
      @movies = @movies.where("rating IN (?)", @picked)
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
