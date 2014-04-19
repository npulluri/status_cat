require 'spec_helper'

describe StatusCat::Checkers::ActiveRecord do

  let( :checker ) { StatusCat::Checkers::ActiveRecord.new.freeze }

  it_should_behave_like 'a status checker'

  it 'provides configuration' do
    yaml =  YAML::load( ERB.new( IO.read( File.join( Rails.root, 'config', 'database.yml' ) ) ).result )
    expected = yaml[ Rails.env ].symbolize_keys!
    checker.config.should eql( expected )
  end

  it 'constructs a value from the configuration' do
    expected = "#{checker.config[ :adapter ]}:#{checker.config[ :username ]}@#{checker.config[ :database ]}"
    checker.value.should eql( expected )
  end

  describe '#status' do

    context 'pass' do

      it 'passes if it can execute a query against the database' do
        ActiveRecord::Base.connection.stub( :execute )
        checker = StatusCat::Checkers::ActiveRecord.new
        checker.status.should be_nil
      end

    end

    context 'fail' do

      it 'returns an error message if it fails to query the database' do
        fail = 'This is only a test'
        ActiveRecord::Base.connection.should_receive( :execute ).and_raise( fail )
        checker = StatusCat::Checkers::ActiveRecord.new
        checker.status.to_s.should eql( fail )
      end

    end

  end

end