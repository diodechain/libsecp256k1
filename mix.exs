defmodule Mix.Tasks.Compile.Libsecp256k1Make do
  use Mix.Task
  @moduledoc false

  def run(args) do
    if :os.type() != {:win32, :nt} or not File.exists?("priv/libsecp256k1_nif.dll") do
      Mix.shell().info("Compiling nif libsecp256k1 with args: #{inspect(args)}")

      case System.cmd("make", ["-C", "."]) do
        {_, 0} -> :ok
        {error, code} -> {:error, ["Failed to compile NIF: #{inspect({code})}", error]}
      end
    else
      Mix.shell().info("libsecp256k1 nif already compiled")
    end
  end
end

defmodule Libsecp256k1.Mixfile do
  use Mix.Project

  def project do
    [
      app: :libsecp256k1,
      version: "0.1.17",
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
      compilers: [:libsecp256k1_make] ++ Mix.compilers(),
      deps: deps()
    ]
  end

  def application() do
    [extra_applications: [common_test: :optional, edoc: :optional, eunit: :optional, mix: :optional]]
  end

  defp deps() do
    [
      {:ex_doc, "~> 0.17", only: :dev, runtime: false}
    ]
  end
end
