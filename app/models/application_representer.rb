# frozen_string_literal: true
# rbs_inline: enabled

class ApplicationRepresenter
  include ActiveModel::Model
  include ActiveModel::Attributes
  include TextRepresenter::Representable

  # For RBS
  extend ActiveModel::Attributes::ClassMethods
  extend ActiveModel::Validations::ClassMethods
end
