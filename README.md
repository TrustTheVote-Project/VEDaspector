# VEDaspector

VEDaspector is a tool for exploring election reports in the VSSC election data format.

To get started, you‘ll need to create your database tables and load an election report:

    $ rake db:migrate
    $ rails console
    > report = Vssc::ElectionReport.parse_vssc_file("MyVSSCFile.xml")
    > report.save!

Then, start your rails application (`rails server`) and you can browse it at `http://localhost:3000`.
