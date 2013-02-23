require 'packet_type_repository'

module Geary

  describe PacketTypeRepository do

    it 'stores packet types by an identifier and their magic code' do
      repository = PacketTypeRepository.new 
      type = double('Packet')
      repository.store("M", 'id', type)

      expect(repository.find("M", 'id')).to eql(type)
    end

    it 'distinguishes two types by their magic code' do
      repository = PacketTypeRepository.new
      type_req = double('Request')
      type_res = double('Response')

      repository.store("M1", 'id', type_req)
      repository.store("M2", 'id', type_res)

      expect(repository.find('M1', 'id')).to eql(type_req)
    end

    it 'raises TypeNotFound if it cannot find a given type' do
      repository = PacketTypeRepository.new
      type = double('Packet')

      repository.store('M', 'id', type)

      expect do
        repository.find('M', 'sly-d')
      end.to raise_error(PacketTypeRepository::TypeNotFound)
    end

    it 'raises MagicNotFound if it does not know about a given Magic code' do
      repository = PacketTypeRepository.new
      type = double('Packet')

      repository.store('M', 'id', type)

      expect do
        repository.find('N', 'id')
      end.to raise_error(PacketTypeRepository::MagicNotFound)
    end

    it 'finds packet types with symbols or strings' do
      repository = PacketTypeRepository.new
      type = double('Packet')

      repository.store('M', 'id', type)

      expect(repository.find('M', :id)).to eql(type)
    end

    it 'finds packet types without regard for case' do
      repository = PacketTypeRepository.new
      type = double('Packet')

      repository.store('M', 'id', type)

      expect(repository.find('M', 'ID')).to eql(type)
    end

  end

end
