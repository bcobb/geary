require 'gearmand_control'

require 'geary/configuration'
require 'geary/manager'

require 'support/fake_performer'
require 'support/with_tolerance'
require 'support/without_logging'

module Geary

  describe Manager do
    include WithTolerance
    include WithoutLogging

    let(:configuration) do
      configuration = Configuration.new(
        server_addresses: ['localhost:4730'],
        concurrency: 2
      )
    end

    describe 'starting the manager' do

      it 'establishes a link to managed performers' do
        manager = Manager.new(configuration: configuration,
                              performer_type: FakePerformer)
        manager.start

        expect(manager.links.count).to eql(2)
      end

      it 'starts each managed performer' do
        manager = Manager.new(configuration: configuration,
                              performer_type: FakePerformer)
        manager.start

        expect(manager.links.all?(&:started?)).to be_true
        expect(manager.links.map(&:server_address).uniq).
          to eql(configuration.server_addresses)
      end

    end

    describe 'performer supervision' do

      it 'restarts performers when they die' do
        without_logging do
          manager = Manager.new(configuration: configuration,
                                performer_type: FakePerformer)
          manager.start

          imminently_dead_performers = manager.performers
          imminently_dead_performers.map(&:async).each(&:die)

          with_tolerance do
            expect(imminently_dead_performers.count(&:alive?)).to eql(0)
          end

          with_tolerance do
            expect(manager.links.count).to eql(2)
          end
        end
      end

      it 'forgets performers if they die without a reason' do
        without_logging do
          manager = Manager.new(configuration: configuration,
                                performer_type: FakePerformer)
          manager.start

          forgettable_performers = manager.performers
          forgettable_performers.map(&:async).each(&:die_quietly)

          with_tolerance do
            expect(forgettable_performers.count(&:alive?)).to eql(0)
          end

          with_tolerance do
            expect(manager.links.count).to eql(0)
          end
        end
      end

    end

    describe 'ceasing management' do

      it 'terminates linked performers' do
        manager = Manager.new(configuration: configuration,
                              performer_type: FakePerformer)
        manager.start

        performers = manager.performers

        expect do
          manager.stop
        end.to change { performers.count(&:alive?) }.from(2).to(0)
      end

      it 'unlinks linked performers' do
        manager = Manager.new(configuration: configuration,
                              performer_type: FakePerformer)
        manager.start

        expect do
          manager.stop
        end.to change { manager.links.count }.from(2).to(0)
      end

      it 'signals that it has stopped' do
        manager = Manager.new(configuration: configuration,
                              performer_type: FakePerformer)
        manager.async.start
        manager.async.stop

        expect(manager.wait :done).to be_nil
      end

    end

  end
end
