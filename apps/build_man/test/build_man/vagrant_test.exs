defmodule BuildMan.VagrantTest do
  alias BuildMan.Vagrant
  alias BuildMan.LogProcessor
  use ExUnit.Case, async: false # Mocks are sync
  import Mock

  @example_project_repo "https://github.com/rabbit-ci/example-project.git"

  @tag :external
  @tag timeout: 200_000
  test "Vagrant worker should run simple build" do
    with_mock LogProcessor, [process: mock_process(self)] do
      {:ok, builder} = Vagrant.start(["blahblahblah",
                               %{box: "ubuntu/vivid64",
                                 script: "cat static_file.txt",
                                 repo: @example_project_repo}])
      Process.monitor(builder)
      assert_receive :got_file_output, 150_000

      # Don't exit until the builder finishes cleaning up
      assert_receive {:DOWN, _ref, _, ^builder, _}, 20_000
    end
  end

  defp mock_process(pid) do
    fn payload, _ ->
      str = "This file should not be modified after its initial commit."
      if String.contains?(payload, str) do
        send(pid, :got_file_output)
      end
    end
  end
end
