class PrincetonCasController < Devise::CasSessionsController
  # Rails <= 3 skip_before_filter :redirect_to_sign_in, only: [:new]
  skip_before_action :redirect_to_sign_in, only: [:new]

  def new
    redirect_to(cas_login_url)
  end
end