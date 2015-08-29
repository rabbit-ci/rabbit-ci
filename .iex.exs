alias RabbitCICore.Repo

alias RabbitCICore.Build
alias RabbitCICore.Project
alias RabbitCICore.Log
alias RabbitCICore.Branch
alias RabbitCICore.Script

# Elixir does not support this currently,
# https://github.com/elixir-lang/elixir/issues/3328

# defmodule MultiAlias do
#   defmacro multi_alias(prefix, mods) do
#     prefix = Macro.expand(prefix, __CALLER__)

#     for {_, _, [mod]} <- mods do
#       submod = Module.concat([mod])
#       mod = Module.concat(prefix, mod)

#       quote do
#         alias unquote(mod), as: unquote(submod)
#       end
#     end
#   end
# end

# require MultiAlias
# MultiAlias.multi_alias RabbitCICore, [Build, Project]
