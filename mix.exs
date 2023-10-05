defmodule Mix.Tasks.Compile.MakeBindings do
  def run(_) do
    {_, exit_code} = System.cmd("make", [], into: IO.stream(:stdio, :line))

    case exit_code do
      0 -> :ok
      _ -> :error
    end
  end
end

defmodule Libsecp256k1.Mixfile do
  use Mix.Project

  def project do
    [
      app: :libsecp256k1,
      version: "0.1.15",
      language: :erlang,
      description: "Erlang NIF bindings for the the libsecp256k1 library",
      package: [
        name: "libsecp256k1_diode_fork",
        files: [
          "LICENSE",
          "Makefile",
          "README.md",
          "c_src/libsecp256k1_nif.c",
          "etest/libsecp256k1_tests.erl",
          "mix.exs",
          "priv/.empty",
          "priv/libsecp256k1_nif.dll",
          "src/libsecp256k1.erl",
          "lib"
        ],
        maintainers: ["Dominic Letz"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/diodechain/libsecp256k1",
          "Forked from" => "https://github.com/exthereum/libsecp256k1"
        }
      ],
      compilers: [:make_bindings, :erlang, :app, :elixir],
      deps: deps()
    ]
  end

  def application() do
    [extra_applications: [common_test: :optional, edoc: :optional, eunit: :optional]]
  end

  defp deps() do
    [
      {:ex_doc, "~> 0.17", only: :dev, runtime: false}
    ]
  end
end
