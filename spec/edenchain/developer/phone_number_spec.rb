RSpec.describe "Generation or retrieval of 1,000,000 phone numbers" do
  it "should successfully generate and store 1,000,000 phone numbers (if not already done) or simply return previously generated 1,000,000 phone numbers" do
    size            =   1_000_000
    phone_numbers   =   ::Edenchain::Developer::Bounty::Data::Seeder.phone_numbers(size: size)
    expect(phone_numbers.size).to eq size
  end
end
