local M = {}

math.randomseed(os.time())

function M:peek()
  local cache = ya.file_cache(self)
  if cache then
    ya.image_show(cache, self.area)
    ya.preview_widgets(self, {})
  end

  local child, code = Command("lsar")
      :args({
        tostring(self.file.url),
      })
      :stdout(Command.PIPED)
      :stderr(Command.PIPED)
      :spawn()

  if code then
    ya.err("lsar error: " .. code)
    return
  end

  local i, current = -1, ""
  repeat
    local next, event = child:read_line()
    if event ~= 0 then
      break
    end

    current = next:gsub("\n", "")

    if current:find("%.*%.[jJ][pP][gG]") or current:find("%.*%.[pP][nN][gG]") then
      break
    end

    i = i + 1
  until i > 10

  child:start_kill()

  local random = math.random(1000000, 9999999)
  local outdir = "/tmp/yazi-" .. random

  child = Command("unar")
      :args({
        "-f",
        "-D",
        "-o",
        outdir,
        "-i",
        tostring(self.file.url),
        tostring(i),
      })
      :stdout(Command.PIPED)
      :stderr(Command.PIPED)
      :spawn()

  local status = child:wait()

  if status:success() then
    local extracted = outdir .. "/" .. current
    child = Command("convert")
        :args({
          extracted,
          "-resize",
          "480",
          tostring(cache),
        })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :spawn()
    status = child:wait()
    if not status:success() then
      ya.err("convert error: " .. extracted)
      local data = nil
      repeat
        data = child:read_line()
        ya.err(data)
      until data
      return
    end

    ya.image_show(cache, self.area)
    ya.preview_widgets(self, {})

    child = Command("rm")
        :args({
          "-r",
          outdir,
        })
        :spawn()
    child:wait()
  end
end

function M:seek(units)
  local h = cx.active.current.hovered
  if h and h.url == self.file.url then
    local step = math.floor(units * self.area.h / 10)
    ya.manager_emit("peek", {
      tostring(math.max(0, cx.active.preview.skip + step)),
      only_if = tostring(self.file.url),
    })
  end
end

return M
