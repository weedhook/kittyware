local profiler = {}
profiler.__index = profiler

function profiler.new()
    local self = setmetatable({}, profiler)
    self.timings = {}
    return self
end

function profiler.start(self, name)
    self.timings[name] = self.timings[name] or { count = 0, total_time = 0, last_time = 0 }
    self.timings[name].count = self.timings[name].count + 1
    self.timings[name].start_time = tick()
end

function profiler.stop(self, name)
    if self.timings[name] then
        local elapsed_time = tick() - self.timings[name].start_time
        self.timings[name].total_time = self.timings[name].total_time + elapsed_time
        self.timings[name].last_time = elapsed_time
    end
end

function profiler.log(self)
    for name, stats in pairs(self.timings) do
        rconsoleprint(string.format("[profiler] loop: %s | count: %d | last time: %.6f seconds | total time: %.6f seconds\n", 
            name, stats.count, stats.last_time, stats.total_time))
    end
end

function profiler.check_alerts(self, threshold)
    threshold = threshold or 0.01
    for name, stats in pairs(self.timings) do
        if stats.last_time > threshold then
            rconsoleprint(string.format("[alert] loop %s exceeded threshold! last time: %.6f seconds\n", name, stats.last_time))
        end
    end
end

function profiler.reset(self)
    self.timings = {}
end

return profiler;
