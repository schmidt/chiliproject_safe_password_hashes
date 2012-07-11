class SafePasswordHashes::Stats
  unloadable

  class Algorithm < Struct.new(:key, :work_load, :registered_users, :active_users, :locked_users)
    def name
      name = key
      name += [' (', work_load, ')'].join if work_load.present?
      name
    end

    def all_users
      [registered_users, active_users, locked_users].sum
    end
  end

  def algorithms
    @algorithms ||= fetch_data
  end

  protected

  def fetch_data
    result = User.connection.execute %Q{
      SELECT
        count(*) AS no,
        password_hash_function,
        password_hash_work_load,
        status
      FROM #{User.quoted_table_name}
      GROUP BY
        password_hash_function,
        password_hash_work_load,
        status
    }

    result.group_by { |row| [row['password_hash_function'],
                             row['password_hash_work_load']]}.map do |x, rows|

      a = Algorithm.new(x.first, x.second, 0, 0, 0)

      rows.each do |row|
        count = row['no'].to_i

        case row['status'].to_i
        when User::STATUS_ANONYMOUS
          # do nothing
        when User::STATUS_REGISTERED
          a.registered_users = count
        when User::STATUS_ACTIVE
          a.active_users = count
        when User::STATUS_LOCKED
          a.locked_users = count
        end
      end

      a
    end
  end
end
