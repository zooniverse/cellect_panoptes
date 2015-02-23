#Create the set of data to benchmark with start with
#fig run --rm --entrypoint=/bin/bash cellect -c "benchmark/create_csv_data.rb"
#fig run --rm --entrypoint=/bin/bash cellect -c "benchmark/create_db_schema.rb"
#fig run --rm --entrypoint=/bin/bash cellect -c "benchmark/load_csv_data.rb"

#
1. load a workflow for a user

2. select some subjects for users.

32. update seen subjects for users / simulate classifications coming down
# user_seen_subjects = []
# sets.each do |set|
#   set.push(workflow_id)
# end
#
# subject_ids = sets.flat_map{ |s| subjects.select{ |ss| ss[1] == s[0] }.map{ |s| s[0] } }
#
# users_per_workflow = 10_000 + rand(50_000)
# user_seen_subjects_id_offset = 1
#
# user_seen_distribution = []
# 380.times{ user_seen_distribution << [    1,      10] }
# 180.times{ user_seen_distribution << [   10,      20] }
# 230.times{ user_seen_distribution << [   20,      50] }
#  90.times{ user_seen_distribution << [   50,     100] }
# 100.times{ user_seen_distribution << [  100,   1_000] }
#  17.times{ user_seen_distribution << [1_000,   5_000] }
#   3.times{ user_seen_distribution << [5_000, 50_000] }
#
# 1.upto(users_per_workflow).each do |user_id|
#   user_seen_range = user_seen_distribution.sample
#   seen_count = user_seen_range[0] + rand(user_seen_range[1])
#   seen_ids = subject_ids.sample(seen_count)
#   user_seen_subjects << [user_id + user_seen_subjects_id_offset, "\"{#{ seen_ids.join(",") }}\"", workflow_id, user_id]
#
# end
# user_seen_subjects_id_offset += users_per_workflow
# File.open("#{FILE_PREFIX}/user_seen_subjects.csv", 'w') { |f| f.write(user_seen_subjects.map{ |l| l.join(',') }.join("\n")) }
