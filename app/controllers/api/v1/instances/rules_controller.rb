# frozen_string_literal: true

class Api::V1::Instances::RulesController < Api::BaseController
  skip_before_action :require_authenticated_user!
  skip_around_action :set_locale

  before_action :set_rules

  vary_by ''

  # Override `current_user` to avoid reading session cookies unless in whitelist mode
  def current_user
    super if whitelist_mode?
  end

  def index
    cache_even_if_authenticated!
    render json: @rules, each_serializer: REST::RuleSerializer
  end

  private

  def set_rules
    @rules = Rule.ordered
  end
end
