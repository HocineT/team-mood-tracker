require 'rack/utils'

class MoodController < ApplicationController

  before_action :set_cookie

  def set_cookie
    cookies.permanent[:token] = UUID.new.generate unless cookies[:token]
    @token = cookies[:token]
  end

  def mood_params
    params.require(:mood).permit(:state)
  end

  def summary
    @moods = Mood.all

    initial_hash = Hash.new { |hash, key| hash[key] = [] }

    @notes_hash = @moods.inject(initial_hash) do |result, element|
      result[element.created_at.to_date.to_s] << {:state => element.state, :notes => Rack::Utils.escape_html(element.notes)}
      result
    end
    
    puts "notes hash: #{@notes_hash}"

    @grouped_moods = Hash.new { |hash, key| hash[key] = Hash.new(0) }

    @moods.each do |mood|
      date = mood.created_at.to_date
      state = mood.state
      @grouped_moods[date][state] += 1
    end

    setup_start_and_end_dates @grouped_moods

    @grouped_moods
  end

  def setup_start_and_end_dates grouped_moods
    if(params[:start_date] && grouped_moods.keys.include?(Date.parse(params[:start_date])))
      @start_date = params[:start_date]
    else
      @start_date = grouped_moods.keys.first
    end

    if(params[:end_date] && grouped_moods.keys.include?(Date.parse(params[:end_date])))
      @end_date = params[:end_date]
    else
      @end_date = grouped_moods.keys.last
    end
  end

  def new
    @mood = Mood.new
  end

  def create
    mood_tmp = mood_params.to_hash.merge(cookie: @token)
    @mood = Mood.new(mood_tmp)
 
    respond_to do |format|
      if @mood.save
        format.html { redirect_to "/add_note/#{@mood.id}" }
      else
        format.html { render action: 'new' }
        format.json { render json: @mood.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_note
    @mood = Mood.find(params[:id])
    if @mood.cookie != cookies[:token]
      redirect_to "/"
    end
  end

  def update
    @mood = Mood.find(params[:mood][:id])
    
    if params[:mood][:notes] != "(Optional)"
      @mood.notes = params[:mood][:notes]
    end

    if @mood.save()
      redirect_to '/summary'
    else
      respond_to do |format|
        format.html { render action: 'add_note' }
      end
    end
  end

  def stats
  end

  def notes
    @moods = Mood.where.not(notes: nil, notes: '')
  end
end
