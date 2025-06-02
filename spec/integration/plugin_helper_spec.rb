RSpec.describe CodeTeams::Plugin, 'helper integration' do
  def write_team_yml(extra_data: false)
    write_file('config/teams/my_team.yml', <<~YML.strip)
      name: My Team
      extra_data: #{extra_data}
    YML
  end

  before do
    CodeTeams.bust_caches!
    write_team_yml(extra_data: { foo: 'foo', bar: 'bar' })
  end

  describe 'helper methods' do
    context 'with a single implicit method' do
      before do
        test_plugin_class = Class.new(described_class) do
          def test_plugin
            data = @team.raw_hash['extra_data']
            Data.define(:foo, :bar).new(data['foo'], data['bar'])
          end
        end

        stub_const('TestPlugin', test_plugin_class)
      end

      it 'adds a helper method to the team' do
        team = CodeTeams.find('My Team')

        expect(team.test_plugin.foo).to eq('foo')
        expect(team.test_plugin.bar).to eq('bar')
      end

      it 'supports nested data' do
        write_team_yml(extra_data: { foo: { bar: 'bar' } })
        team = CodeTeams.find('My Team')
        expect(team.test_plugin.foo['bar']).to eq('bar')
      end
    end

    context 'with other public methods' do
      before do
        test_plugin_class = Class.new(described_class) do
          def other_method1
            'other1'
          end

          def other_method2
            'other2'
          end
        end

        stub_const('TestPlugin', test_plugin_class)
      end

      it 'adds the other methods to the team' do
        team = CodeTeams.find('My Team')

        expect(team.other_method1).to eq('other1')
        expect(team.other_method2).to eq('other2')
      end
    end
  end
end
