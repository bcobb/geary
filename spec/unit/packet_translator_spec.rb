require 'geary'

module Geary
  describe PacketTranslator do

    subject(:translator) { PacketTranslator.new }

    it 'turns packets with type 17 into Echo packets' do
      magic, type, arguments = ["\0RES", 17, ['test']]

      packet = translator.translate(magic, type, arguments)

      expect(packet).to be_a(Packet::Echo)
      expect(packet.arguments).to eql(['test'])
      expect(packet.data).to eql('test')
    end

    it 'turns packets with type 19 into Error packets' do
      magic, type, arguments = ["\0RES", 19, ['code', 'test error']]

      packet = translator.translate(magic, type, arguments)

      expect(packet).to be_a(Packet::Error)
      expect(packet.arguments).to eql(['code', 'test error'])
      expect(packet.error_code).to eql('code')
      expect(packet.error_text).to eql('test error')
    end

  end
end
