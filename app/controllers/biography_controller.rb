class BiographyController < ApplicationController
  def index

    @skills = Skill.all
    expires_in 3.days, :public => true
    fresh_when(@skills)
    
    @about
    @work_experience = []
    @education = []
    @projects = []

    @skills.each do | skill |
      if skill.skill_type == 'about'
        @about = skill
      elsif skill.skill_type == 'experience'
        @work_experience << skill
      elsif skill.skill_type == 'education'
        @education << skill
      elsif skill.skill_type == 'project'
        @projects << skill
      end

    end

    
  end

  def cv
  end
end
