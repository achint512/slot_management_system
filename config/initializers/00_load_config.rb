# frozen_string_literal: true

INTERVIEW_SLOTS_CONFIG = YAML.load_file("#{Rails.root}/config/interview_slots_config.yml")[Rails.env]
