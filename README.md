# VEDaspector

VEDaspector is a Ruby on Rails application for exploring and modifying election results in the [NIST ERR format](http://www.nist.gov/itl/vote/ieee-swg-p1622.cfm).

To run this application, you'll need to perform the following steps in your command line:

    $ git clone git@github.com:TrustTheVote-Project/VEDaspector.git
    $ cd VEDaspector
    $ bundle install
    $ rake db:migrate
    $ rails server

Once VEDaspector is running, you can import a saved election report by opening `http://localhost:3000/import` in your web browser, or create a blank election report.
