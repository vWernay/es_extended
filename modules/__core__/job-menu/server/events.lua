M('events')

onRequest('job-menu:getJob', function(source, cb)
    local player = xPlayer.fromId(source)

    cb(player.job.name)
end)