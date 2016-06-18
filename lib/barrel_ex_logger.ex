defmodule BarrelExLogger do
  use Bitwise

  @behaviour :gen_event

  def flush() do
    _ = GenEvent.which_handlers(:error_logger)
    _ = GenEvent.which_handlers(:lager_event)
    _ = GenEvent.which_handlers(Logger)
    :ok
  end

  def init(opts) do
    config = Keyword.get(opts, :level, :debug)
    case config_to_mask(config) do
      {:ok, _mask} = ok ->
        ok
      {:error, reason} ->
        {:error, {:fatal, reason}}
    end
  end

  def handle_event({:log, lager_msg}, mask) do
    %{mode: mode, truncate: truncate, level: min_level, utc_log: utc_log?} = Logger.Config.__data__
    level = severity_to_level(:lager_msg.severity(lager_msg))

    if :lager_util.is_loggable(lager_msg, mask, __MODULE__) and
      Logger.compare_levels(level, min_level) != :lt do

      metadata = :lager_msg.metadata(lager_msg) |> normalize_pid
      message = Logger.Utils.truncate(:lager_msg.message(lager_msg), truncate)
      timestamp = timestamp(:lager_msg.timestamp(lager_msg), utc_log?)
      group_leader = case Keyword.fetch(metadata, :pid) do
        {:ok, pid} when is_pid(pid) -> Process.info(pid, :group_leader)
        _ -> Process.group_leader
      end
      _ = notify(mode, {level, group_leader, {Logger, message, timestamp, metadata}})
      {:ok, mask}
    else
      {:ok, mask}
    end
  end

  def handle_call(:get_loglevel, mask) do
    {:ok, mask, mask}
  end

  def handle_call({:set_loglevel, config}, mask) do
    case config_to_mask(config) do
      {:ok, mask} ->
        {:ok, :ok, mask}
      {:error, _reason} = error ->
        {:ok, error, mask}
    end
  end

  def handle_info(_msg, mask) do
    {:ok, mask}
  end

  def terminate(_reason, _mask), do: :ok

  def code_change(_old, mask, _extra), do: {:ok, mask}

  defp config_to_mask(config) do
    try do
      :lager_util.config_to_mask(config)
    catch
      _, _ ->
        {:error, {:bad_log_level, config}}
    else
      mask ->
        {:ok, mask}
    end
  end

  defp notify(:sync, msg),  do: GenEvent.sync_notify(Logger, msg)
  defp notify(:async, msg), do: GenEvent.notify(Logger, msg)

  def normalize_pid(metadata) do
    case Keyword.fetch(metadata, :pid) do
      {:ok, pid} when is_pid(pid) -> metadata
      {:ok, pid} when is_list(pid) ->
        try do
          Keyword.put(metadata, :pid, :erlang.list_to_pid(pid))
        rescue
          ArgumentError -> Keyword.delete(metadata, :pid)
        end
      {:ok, _} -> Keyword.delete(metadata, :pid)
      :error -> metadata
    end
  end

  def timestamp(now, utc_log?) do
    {_, _, micro} = now
    {date, {hours, minutes, seconds}} =
      case utc_log? do
        true  -> :calendar.now_to_universal_time(now)
        false -> :calendar.now_to_local_time(now)
      end
    {date, {hours, minutes, seconds, div(micro, 1000)}}
  end

  defp severity_to_level(:debug),     do: :debug
  defp severity_to_level(:info),      do: :info
  defp severity_to_level(:notice),    do: :info
  defp severity_to_level(:warning),   do: :warn
  defp severity_to_level(:error),     do: :error
  defp severity_to_level(:critical),  do: :error
  defp severity_to_level(:alert),     do: :error
  defp severity_to_level(:emergency), do: :error
end