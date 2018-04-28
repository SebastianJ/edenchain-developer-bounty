RSpec.describe "Managing 1,000,000 SHA256 hashed phone numbers using a Binary Tree" do
  it "should successfully insert 1,000,000 SHA256 hashed phone numbers in the Binary Tree" do
    size            =   1_000_000
    phone_numbers   =   ::Edenchain::Developer::Bounty::Data::Seeder.phone_numbers(size: size)
    
    puts "Creating a new Binary Tree to hold the 1,000,000 SHA256 hashed phone numbers"
    
    genesis         =   Digest::SHA256.hexdigest(phone_numbers.first)
    tree            =   Edenchain::Developer::Bounty::BinaryTree::Node.new(genesis)
    
    phone_numbers.each do |phone_number|
      tree         <<   Digest::SHA256.hexdigest(phone_number)
    end
    
    puts "Binary Tree successfully initialized"
    
    expect(tree.to_a.size).to eq size
    
    first_phone_number  =   Digest::SHA256.hexdigest(phone_numbers[0])
    last_phone_number   =   Digest::SHA256.hexdigest(phone_numbers[-1])
    
    expect(tree.include?(first_phone_number)).to eq true
    expect(tree.include?(last_phone_number)).to eq true
  end
end
