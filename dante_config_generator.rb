# frozen_string_literal: true

require 'net/http'
require 'json'

# Generates dante config with Telegram subnets allowed
class DanteConfigGenerator
  TELEGRAM_DOMAINS = %w[telegram.dog telegram.me telegram.org stel.com
                        t.me].freeze
  RIPE_QUERY = { 'source' => 'ripe',
                 'inverse-attribute' => 'mb,mnt-lower',
                 'query-string' => 'MNT-TELEGRAM',
                 'type-filter' => 'route,route6' }.freeze
  EXTRA_NETWORKS = [
    # Amazon
    '52.58.0.0/15',
    '18.196.0.0/15',
    '18.194.0.0/15',
    '35.156.0.0/14',
    '54.160.0.0/12',
    # Google
    '5.184.0.0/13',
    '35.184.0.0/13',
    '35.208.0.0/12'
  ]

  def generate
    <<~CONFIG
      logoutput: stderr
      internal: eth0 port = 1080
      external: eth0
      clientmethod: none
      socksmethod: #{ENV['with_users'] ? 'username' : 'none' }
      user.privileged: root
      user.unprivileged: nobody

      client pass {
        from: 0.0.0.0/0
        to: 0.0.0.0/0
        log: error
      }

      #{subnet_socks_pass('0.0.0.0/0') if ENV['all_networks']}
      #{subnets_socks_passes.join("\n").strip unless ENV['all_networks']}

      #{domains_socks_passes.join("\n").strip}
    CONFIG
  end

  private

  def domains_socks_passes
    TELEGRAM_DOMAINS.map { |domain| domain_socks_pass(domain) }
  end

  def subnets_socks_passes
    all_subnets = telegram_subnets
    all_subnets.concat(EXTRA_NETWORKS) if ENV['with_users']
    all_subnets.map { |subnet| subnet_socks_pass(subnet) }
  end

  def domain_socks_pass(domain)
    <<~CONFIG
      socks pass {
        from: 0.0.0.0/0
        to: .#{domain}
      }
    CONFIG
  end

  def subnet_socks_pass(subnet)
    ipv6 = subnet.include?(':')
    <<~CONFIG
      socks pass {
        from: #{ipv6 ? '::/0' : '0.0.0.0/0'}
        to: #{subnet}
      }
    CONFIG
  end

  def uri
    URI::HTTPS.build(host: 'rest.db.ripe.net',
                     path: '/search.json',
                     query: RIPE_QUERY.map { |k, v| [k, v].join('=') }
                                      .join('&'))
  end

  def routes
    JSON.parse(Net::HTTP.get(uri))
        .fetch('objects')
        .fetch('object')
  end

  def telegram_subnets
    routes.map do |route|
      route.fetch('primary-key').fetch('attribute').first.fetch('value')
    end
  end
end

if $PROGRAM_NAME == __FILE__
  File.open($ARGV&.first || 'danted.conf', 'w') do |f|
    f.write(DanteConfigGenerator.new.generate)
  end
end
