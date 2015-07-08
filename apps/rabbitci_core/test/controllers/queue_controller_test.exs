defmodule RabbitCICore.QueueControllerTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  import Mock
  import Ecto.Query

  alias RabbitCICore.Repo
  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias RabbitCICore.Build

  test "missing params" do
    response = post("/queue")
    assert response.status == 400
  end

  test "no project with repo" do
    response = post("/queue", %{repo: "xyz", commit: "xyz", branch: "xyz"})
    assert response.status == 404
  end

  test "branch does not exist" do
    project = Repo.insert! %Project{name: "project1", repo: "xyz"}
    response = post("/queue", %{repo: "xyz", commit: "xyz", branch: "xyz"})
    assert response.status == 200
    query = (from b in Branch,
             where: b.project_id == ^project.id and b.name == "xyz")
    assert Repo.one(query) != nil
  end

  test "successful queue" do
    with_mock Exq, [enqueue: fn(_, _, _ , _) -> nil end] do
      p = Repo.insert! %Project{name: "project1", repo: "xyz"}
      b = Repo.insert! %Branch{name: "branch1", exists_in_git: false,
                              project_id: p.id}
      response = post("/queue", %{repo: "xyz", commit: "xyz",
                                  branch: "branch1"})
      assert response.status == 200
      assert called Exq.enqueue(:_, :_, :_, :_)
      query = (from b in Build,
               where: b.branch_id == ^b.id and b.commit == "xyz")
      assert Repo.one(query) != nil
    end
  end

  test "queue a commit again" do
    with_mock Exq, [enqueue: fn(_, _, _ , _) -> nil end] do
      p = Repo.insert! %Project{name: "project1", repo: "xyz"}
      b = Repo.insert! %Branch{name: "branch1", exists_in_git: false,
                              project_id: p.id}
      for _ <- 0..1 do
        response = post("/queue", %{repo: "xyz", commit: "xyz",
                                    branch: "branch1"})
        assert response.status == 200
      end

      query = (from b in Build,
               where: b.branch_id == ^b.id and b.commit == "xyz")
      assert length(Repo.all(query)) == 2
    end
  end

end
