## Setup

VEDaspector is a Ruby on Rails application for exploring and modifying election results in the [NIST ERR format](http://www.nist.gov/itl/vote/ieee-swg-p1622.cfm).

To run this application, you'll need to perform the following steps in your command line:

    $ git clone git@github.com:TrustTheVote-Project/VEDaspector.git
    $ cd VEDaspector
    $ bundle install
    $ rake db:migrate
    $ rails server

Once VEDaspector is running, you can import a saved election report by opening `http://localhost:3000/import` in your web browser, or `http://localhost:3000/election_reports/new` to create a new election report. You can find a sample report file [in the VEDaStore repo](https://github.com/TrustTheVote-Project/VEDaStore/blob/master/spec/fixtures/NY_TEST.xml).


## Implementation

VEDaspector is built using the [VEDaStore Rails engine](https://github.com/TrustTheVote-Project/VEDaStore), which implements parsing and persistence of the entities from the NIST ERR data format. VEDaspector displays a given entity by building an HTML display of its properties. VEDaspector can also generate corresponding editing forms for these properties.

Properties come in three types:

* *Values*: simple data such as text, numbers, and dates which are contained inside the parent entity, e.g. as database columns in the parent entity's row. Some values can be more complex, such as a ContactInformation's email property, which is an array of strings stored as a serialized JSON string.
* *Linked entities*: entities can reference other entities, e.g. an Election Report linking to its Election.
* *Collections*: entities can reference collections of other entities, e.g. an Election containing an collection of its participating Candidates.

## Tests

Some tests have been written for VEDaspector's entity update logic. You can run them with the following:

    $ rake test
