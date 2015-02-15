module Github
  class RankingInitializer
    BATCH_SIZE               = 5000
    USER_RANKING_KEY         = 'githubranking-user-ranking'
    ORGANIZATION_RANKING_KEY = 'githubranking-orgzanization-ranking'
    REPOSITORY_RANKING_KEY   = 'githubranking-repository-ranking'

    def run
      initialize_users
      initialize_organizations
      initialize_repositories
    end

    private

    def initialize_users
      last_id = 0

      loop do
        users = User.not_organization.where('id > ?', last_id).
          limit(BATCH_SIZE).order(id: :asc).pluck(:id, :stargazers_count)
        break if users.blank?

        users.each do |id, stargazers_count|
          redis.zadd(USER_RANKING_KEY, stargazers_count, id) if stargazers_count > 0
        end
        last_id = users.last.first
        print "#{last_id}\r"
      end
      puts
    end

    def initialize_organizations
      last_id = 0

      loop do
        orgs = Organization.where('id > ?', last_id).
          limit(BATCH_SIZE).order(id: :asc).pluck(:id, :stargazers_count)
        break if orgs.blank?

        orgs.each do |id, stargazers_count|
          redis.zadd(ORGANIZATION_RANKING_KEY, stargazers_count, id) if stargazers_count > 0
        end
        last_id = orgs.last.first
        print "#{last_id}\r"
      end
      puts
    end

    def initialize_repositories
      last_id = 0

      loop do
        repos = Repository.where('id > ?', last_id).
          limit(BATCH_SIZE).order(id: :asc).pluck(:id, :stargazers_count)
        break if repos.blank?

        repos.each do |id, stargazers_count|
          redis.zadd(REPOSITORY_RANKING_KEY, stargazers_count, id) if stargazers_count > 0
        end
        last_id = repos.last.first
        print "#{last_id}\r"
      end
      puts
    end

    def redis
      @redis ||= Redis.current
    end
  end
end
