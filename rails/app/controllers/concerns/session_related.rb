module SessionRelated
  private
    def set_session
      @session = Session.find(session_id_param)
    end

    def session_id_param
      params.require(:session_id)
    end

    def add_sessions_breadcrumb
      add_breadcrumb("Sessions", sessions_path)
    end

    def add_session_breadcrumb
      add_breadcrumb(@session.id, session_path(@session))
    end
end
