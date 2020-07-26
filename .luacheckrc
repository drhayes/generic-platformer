std = "love+luajit"
unused_args = false
max_line_length = false
new_read_globals = { 'game', 'inspect', 'media', 'TEsound', 'bit32', 'log' }
new_globals = { 'gameWorld' }
files['test/**/*.lua'] = {
  read_globals = { 'describe', 'it', 'assert', 'before_each' }
}
