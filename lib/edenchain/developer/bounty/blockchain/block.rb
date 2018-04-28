module Edenchain
  module Developer
    module Bounty
      module Blockchain
        
        class Block
          attr_reader   :index
          attr_reader   :timestamp
          attr_accessor :data
          attr_reader   :previous_hash
          attr_reader   :hash

          def initialize(index, items, previous_hash, proof_of_work_difficulty)
            @index                =   index
            @timestamp            =   Time.now.utc
            set_tree(items)
            @previous_hash        =   previous_hash
            @hash                 =   compute_hash_with_proof_of_work(proof_of_work_difficulty)
          end
          
          def set_tree(items)
            genesis               =   items.first
            @data                 =   Edenchain::Developer::Bounty::BinaryTree::Node.new(genesis)

            items.each do |item|
              @data              <<   item
            end
          end
          
          def hash_string(nonce = nil)
            hashed                =   "#{@index}#{@timestamp}#{@tree.to_a}#{@previous_hash}"
            hashed               +=   nonce.to_s unless nonce.to_s.empty?
            
            return hashed
          end
          
          def compute_hash_with_proof_of_work(difficulty)
            # If difficulty is nil it means that PoW has been disabled
            # Just calculate the hash without a nonce in that case
            
            if difficulty.nil?
              return calculate_hash
            else
              nonce                 =   0
            
              loop do
                hash                =   calculate_hash(nonce)
              
                if hash.start_with?(difficulty)
                  return [nonce, hash]
                else
                  nonce            +=   1
                end
              end
            end
          end
          
          def calculate_hash(nonce = nil)
            sha = Digest::SHA256.new
            sha.update(hash_string(nonce))
            sha.hexdigest
          end
          
          def item_address(item_hash)
            "#{@index}x#{item_hash}"
          end

          def self.first(items, proof_of_work_difficulty)
            Block.new(0, items, "0", proof_of_work_difficulty)
          end

          def self.next(previous, items, proof_of_work_difficulty)
            Block.new(previous.index + 1, items, previous.hash, proof_of_work_difficulty)
          end
        end
        
      end
    end
  end
end
