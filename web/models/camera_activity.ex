defmodule CameraActivity do
  use EvercamMedia.Web, :model
  import Ecto.Changeset
  import Ecto.Query
  alias EvercamMedia.SnapshotRepo

  @required_fields ~w(camera_id action)
  @optional_fields ~w(access_token_id camera_exid name action extra done_at)

  schema "camera_activities" do
    belongs_to :camera, Camera
    belongs_to :access_token, AccessToken

    field :action, :string
    field :done_at, Ecto.DateTime, default: Ecto.DateTime.utc
    field :extra, EvercamMedia.Types.JSON
    field :camera_exid, :string
    field :name, :string
  end

  def log_activity(user, camera, action) do
    access_token = AccessToken.active_token_for(user.id)
    params = %{
      camera_id: camera.id,
      camera_exid: camera.exid,
      access_token_id: get_access_token_id(access_token),
      name: User.get_fullname(user),
      action: action,
      done_at: Ecto.DateTime.utc
    }
    %CameraActivity{}
    |> changeset(params)
    |> SnapshotRepo.insert
  end

  defp get_access_token_id(nil), do: nil
  defp get_access_token_id(access_token), do: access_token.id

  def changeset(camera_activity, params \\ :invalid) do
    camera_activity
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:camera_id, name: :camera_activities_camera_id_done_at_index)
  end
end
