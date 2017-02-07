class BiographyController < ApplicationController
  def index
    @about = Skill.where(skill_type: 'about').first
    @work_experience = Skill.where(skill_type: 'experience')
    @education = Skill.where(skill_type: 'education')
    @projects = Skill.where(skill_type: 'project')

  end
end
