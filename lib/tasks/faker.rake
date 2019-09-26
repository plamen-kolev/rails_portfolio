namespace :faker do
  desc "TODO"
  task init: :environment do

    Rake::Task['db:purge'].invoke
    Rake::Task['db:migrate'].invoke

    a = Article.new
    a.title = <<-HEREDOC
      Data classification using Neural Networks and Genetic Programming
HEREDOC
    a.body = Kramdown::Document.new(File.read("#{Rails.root}/resources/articles/machine_learning.md")).to_html
    a.tags = 'Neural networks, Genetic Programming, MLP, Machine Learning, epochx, classification, sigmoidal'
    a.created_at = "2018-07-01 08:10:53.926767"
    a.updated_at = "2018-07-01 08:10:53.926767"
    a.save

    # now to generate artworks
    for i in %w(cr.jpg hackne_logo.jpg hackne_poster.jpg hackne_print.jpg lloyds_bank.jpg lux.png neven.jpg spendwell_poster.jpg spenwell_app.jpg stage_tuts.jpg)
      
      File.open("#{Rails.public_path}/media/images/creative/#{i}") do |f|
        Artwork.create(
          image: f
        )
      end
    end

    # generate cv content

    data = [ { :type => 'about', :title => '', :body =>
      Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/about.md")).to_html,
        :date => ''
      },
      # ======= EXPERIENCE
            {
        :type => 'experience',
        :title => 'Software Engineer, <br/>BookingGo',

        :date => 'November 2018 - Present',
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/work/bookinggo.md")).to_html,
      },
      {
        :type => 'experience',
        :title => 'Software Engineer, <br/>The Hut Group',

        :date => 'August 2017 - October 2018',
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/work/thg.md")).to_html,
      },
      {
        :type => 'experience',
        :title => 'Software Engineer Intern,<br/> Intel Corporation',
        :date => 'August 2015 - September 2016',
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/work/intel.md")).to_html,
      },
      # ===== EDUCATION
      {
        :type => 'education',
        :title => 'BSc. Computer Science, <br/>Newcastle University',
        :date => 'September 2013 - June 2017',
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/education/newcastle-university.md")).to_html,

      },
      # =============== PROJECTS
      {
        :type => 'project',
        :title => "Songs of the World",
        :date => "August 2019 - September 2019",
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/projects/songs.md")).to_html,
      },
      {
        :type => 'project',
        :title => "Web Platform for Digital Deployment of Virtual Servers",
        :date => "November 2016 - June 2017",
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/projects/dissertation.md")).to_html,
      },
      {
        :type => 'project',
        :title => 'Neven Body Care',
        :date => '5 August - 28 August 2016',
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/projects/neven.md")).to_html,
      },
      {
        :type => 'project',
        :title => 'Secure Coding Presentation',
        :date => "5 May 2016",
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/projects/secure-coding.md")).to_html,
      },
      {
        :type => 'project',
        :title => 'SpendWell, <br/>Lloyds Banking Application',
        :date => '31 October 2014',
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/projects/lloyds.md")).to_html,
      },
      {
        :type => 'project',
        :title => "HackNE Hackathon, <br/> Newcastle University",
        :date => '31 October 2014',
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/projects/hackne.md")).to_html,
      },
      {
        :type => 'project',
        :title => 'Lights Automation, <br/>PAConsulting',
        :date => '12 February 2014',
        :body => Kramdown::Document.new(File.read("#{Rails.root}/resources/biography/projects/paconsulting.md")).to_html,
      }

    ]

    
    for i in data do
      Skill.create(
        skill_type:   i[:type],
        title:  i[:title],
        date:   i[:date],
        body:   i[:body]
      )
    end
    
    # Now generate the static website
    all_articles = Article.all
    ## index
    index_page = PagesController.render(
      template: 'pages/index',
      assigns: { articles: all_articles }
    )

    articles_all = PagesController.render(
      template: 'articles/index',
      assigns: { articles: all_articles }
    )

    creative = PagesController.render(
      template: 'creatives/index',
      assigns: { artworks: Artwork.all }
    )


    # grab all bio relevant stuff
    @skills = Skill.all
    
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

    biography = PagesController.render(
      template: 'biography/index',
      assigns: { 
        about: @about,
        work_experience: @work_experience,
        education: @education,
        projects: @projects
      }
    )

    four_oh_four = PagesController.render(
        template: 'pages/error_404'
    )

    keybase = PagesController.render(
        text: "hKRib2R5hqhkZXRhY2hlZMOpaGFzaF90eXBlCqNrZXnEIwEgW516ZGqInOKwnCCB/dPKp1aAR16qXYAujMhztq47F7MKp3BheWxvYWTFAvN7ImJvZHkiOnsia2V5Ijp7ImVsZGVzdF9raWQiOiIwMTIwNWI5ZDdhNjQ2YTg4OWNlMmIwOWMyMDgxZmRkM2NhYTc1NjgwNDc1ZWFhNWQ4MDJlOGNjODczYjZhZTNiMTdiMzBhIiwiaG9zdCI6ImtleWJhc2UuaW8iLCJraWQiOiIwMTIwNWI5ZDdhNjQ2YTg4OWNlMmIwOWMyMDgxZmRkM2NhYTc1NjgwNDc1ZWFhNWQ4MDJlOGNjODczYjZhZTNiMTdiMzBhIiwidWlkIjoiYjI3ZDliY2VjNmQyOTQ2NTcxYTI4MDUyZTVlMWJkMTkiLCJ1c2VybmFtZSI6InBsYW1lbmtvbGV2In0sInNlcnZpY2UiOnsiaG9zdG5hbWUiOiJrb2xldi5pbyIsInByb3RvY29sIjoiaHR0cDoifSwidHlwZSI6IndlYl9zZXJ2aWNlX2JpbmRpbmciLCJ2ZXJzaW9uIjoxfSwiY2xpZW50Ijp7Im5hbWUiOiJrZXliYXNlLmlvIGdvIGNsaWVudCIsInZlcnNpb24iOiIxLjAuMTgifSwiY3RpbWUiOjE0ODc3MDA2MTEsImV4cGlyZV9pbiI6NTA0NTc2MDAwLCJtZXJrbGVfcm9vdCI6eyJjdGltZSI6MTQ4NzcwMDYwMiwiaGFzaCI6ImMwYzJiNzhhMTBlOWM2ZTkzYTcyYWIzYWQ1M2ZmZWU2MzNkOTU3ODdmYzU3YjY5NDdjMzYzNTQxYzc4ZjcyNWQ2YWYxZTE1MDc4ZjdjN2FkMWY3ZWQwYTViOTJiZDY4MzA3YTdiYWZjOTM0NzNiZDVlZDZkMjdmZWNlYWI5MTU1Iiwic2Vxbm8iOjkxMTI0OX0sInByZXYiOiJkNzVhNDczZDUxOTBjZmM0ZDQyMmJhY2M5ODg5ZjFmNzk2ZDkxNThjN2JjODQwZGE1ZDk3OGY4YmQyNjg3MzgwIiwic2Vxbm8iOjE3LCJ0YWciOiJzaWduYXR1cmUifaNzaWfEQCXV2wYy8DQAToIZpBq7BRIHvx757tI30SqPwXLJKJ+PWp91+I8WY9KxQLIpN9t9LcaNFGm8FJqh75aG3ITUIAGoc2lnX3R5cGUgpGhhc2iCpHR5cGUIpXZhbHVlxCA8LYZBNOM5DjSHiQSvZ0VddSOO+58J7kZSyFwMLwAUeqN0YWfNAgKndmVyc2lvbgE="
    )

    cname = PagesController.render(
        text: "kolev.io"
    )

    robots = PagesController.render(
        text: <<-HERE
User-agent: *
Disallow:
HERE
    )

    Rake::Task['assets:precompile'].invoke

    # before file operations, create dependant folders
    static_dir = 'plamen-kolev.github.io'
    Dir.mkdir(static_dir) unless File.exists?(static_dir)
    Dir.mkdir("#{static_dir}/articles") unless File.exists?("#{static_dir}/articles")
    File.open("plamen-kolev.github.io/index.html", "w") { |file| file.write(index_page) }
    File.open("plamen-kolev.github.io/articles.html", "w") { |file| file.write(articles_all) }
    File.open("plamen-kolev.github.io/creative.html", "w") { |file| file.write(creative) }
    File.open("plamen-kolev.github.io/biography.html", "w") { |file| file.write(biography) }
    File.open("plamen-kolev.github.io/404.html", "w") { |file| file.write(four_oh_four) }
    # keybase verification signature
    File.open("plamen-kolev.github.io/keybase.txt", "w") { |file| file.write(keybase) }
    # CNAME from namecheap
    File.open("plamen-kolev.github.io/CNAME", "w") { |file| file.write(cname) }
    File.open("plamen-kolev.github.io/robots.txt", "w") { |file| file.write(robots) }

    # now to write each article
    all_articles.each do |article|
      html_article = PagesController.render(
        template: 'articles/show',
        assigns: { article: article }
      )
      File.open("plamen-kolev.github.io/articles/#{article.slug}.html", "w") { |file| file.write(html_article) }
    end


    FileUtils.copy_entry "#{Rails.public_path}/assets", "#{Rails.root}/plamen-kolev.github.io/assets/"
    FileUtils.copy_entry "#{Rails.public_path}/media", "#{Rails.root}/plamen-kolev.github.io/media"
  end



end
