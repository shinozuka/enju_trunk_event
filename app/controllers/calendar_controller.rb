class CalendarController < ApplicationController
  add_breadcrumb "I18n.t('page.calendar')", 'calendar_path'
  helper_method :get_library, :get_libraries

  def index
    params[:month] ||= Time.zone.now.month
    params[:year] ||= Time.zone.now.year
    @month = params[:month].to_i || Time.zone.now.month
    @year = params[:year].to_i || Time.zone.now.year

    #@shown_month = Date.civil(@year, @month)
    @shown_month = Time.zone.local(@year, @month, 1) rescue Time.zone.now

    # TODO: Solrを使って取得
    role_id = current_user.role.id rescue nil || Role.where(:name => 'Guest').first.id
    if get_library
      @event_strips = Event.at(@library).where("required_role_id <= #{role_id}").event_strips_for_month(@shown_month)
    else
      @event_strips = Event.where("required_role_id <= #{role_id}").event_strips_for_month(@shown_month)
    end
    get_libraries
  end

  def show
    date = Time.zone.local(params[:year].to_i, params[:month].to_i, params[:day].to_i) rescue Time.zone.now
    date_string = date.strftime('%Y/%m/%d')
    if Event.search do
      with(:start_at).less_than_or_equal_to date
      with(:end_at).greater_than date
    end.results.empty?
      redirect_to new_event_path(:date => date_string)
    else
      redirect_to events_path(:date => date_string)
    end
  end
end
