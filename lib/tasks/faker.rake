
markdown = markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
namespace :faker do
  desc "TODO"
  task init: :environment do

    Rake::Task['db:purge'].invoke
    Rake::Task['db:migrate'].invoke

    a = Article.new
    a.title = <<-HEREDOC
      Data classification using Neural Networks and Genetic Programming
HEREDOC
    a.body = markdown.render(File.read("#{Rails.root}/articles/machine_learning.md"))
    a.tags = 'Neural networks, Genetic Programming, MLP, Machine Learning, epochx, classification, sigmoidal'
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
markdown.render(<<-HERE), 
My name is Plamen Kolev and I specialize in web
application development, system automation and deployment. I have over 3 years
of experience working in world leading companies as a software engineer.  
I have worked with established technologies such as Enterprise Java, Perl, Ruby Bash
and Linux. I have also worked with new and emerging technologies such as Docker,
Hazelcast; in-memory data grid, Amazon Web Services, React and Node JS. In my
professional experience, I have used established software patterns and
methodologies to deliver high quality, reliable, and robust software.

I believe in Scrum and Agile methodologies to deliver incremental and sustainable solutions and have practised extreme programming and mobbing to deliver higher-quality code.  

I am a strong team player and like taking initiative and ownership of the work that I do.  
I'm an advocate for test driven development. Linux and open-source technologies are a strong passion of mine.
HERE
        :date => ''
      },
      # ======= EXPERIENCE
      {
        :type => 'experience',
        :title => 'Software Engineer, <br/>The Hut Group',

        :date => 'August 2017 - Present',
        :body => markdown.render(<<-HERE),
Worked on the in-house warehouse management system as part of the Internal Movements Team. 
Delivered features in *Agile* environment. 
Also wrote a library for testing and automation to accelerate the development process.
HERE
      },
      {
        :type => 'experience',
        :title => 'Software Engineer Intern,<br/> Intel Corporation',
        :date => 'August 2015 - September 2016',
        :body => markdown.render(<<-HERE),
Worked on high-performing, Cyber Security projects. 
Created automated tests using BASH, Perl and in-house tools. 
Developed scripts to automate product integration and deployment as part of a large, multi-national team.
HERE
      },
      # ===== EDUCATION
      {
        :type => 'education',
        :title => 'BSc. Computer Science, <br/>Newcastle University',
        :date => 'September 2013 - June 2017',
        :body => markdown.render(<<-HERE),
Achieved First Class Honours degree in Computer Science with Industrial Placement. 
Studied software design & development. Relational Database technologies, Computer Architecture: Parallel computing and Biocomputing.
HERE

      },
      # =============== PROJECTS
      {
        :type => 'project',
        :title => "Web Platform for Digital Deployment of Virtual Servers",
        :date => "November 2016 - June 2017",
        :body => <<-HERE
Created a platform for deployment, management and monitoring of virtual servers as part of BSC final year dissertation. Technologies used: Puppet, BASH shell, Virtualbox, Vagrant, Ruby, Ruby On Rails.
HERE
      },
      {
        :type => 'project',
        :title => 'Neven Body care',
        :date => '5 August - 28 August 2016',
        :body => <<-HERE,
Created a PHP website for the Neven brand as part of a case study for creating web platforms. The project aimed to create an interactive system for featuring natural care products.
HERE
      },
      {
        :type => 'project',
        :title => 'Secure Coding Presentation',
        :date => "5 May 2016",
        :body => <<-HERE,
Gave a presentation in Leicester College about different ways code can be exploited by a malicious user and ways to mitigate and avoid such cases.

HERE
      },
      {
        :type => 'project',
        :title => 'Lloyds Banking',
        :date => '31 October 2014',
        :body => <<-HERE,
Developed and designed a website with restful API that hooks to an Android application for the British bank Lloyds. The product was produced as part of a team project.
HERE
      },
      {
        :type => 'project',
        :title => "HackNE Hackathon",
        :date => '31 October 2014',
        :body => <<-HERE
        Co-organized a hackathon in the North East, United Kingdom backed by Major League Hacking EU. Created the website for the event, PR and print design materials.

HERE
      },
      {
        :type => 'project',
        :title => 'PAConsulting',
        :date => '12 February 2014',
        :body => <<-HERE,
        Developed an environmental friendly hardware & software solution with the Raspberry Pi that involves predictive light automation and control.

HERE
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
