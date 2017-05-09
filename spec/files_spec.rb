require 'spec_helper'

RSpec.describe Files do
  it 'has a version number' do
    expect(Files::VERSION).not_to be nil
  end
end
