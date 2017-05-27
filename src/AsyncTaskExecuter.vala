private class AsyncTask : GLib.Object {
  private bool _isActive;
  private int _timeout;
  private AsyncTaskExecuter _parent;

  public AsyncTask(AsyncTaskExecuter parent, int timeout) {
    _parent = parent;
    _timeout = timeout;
  }

  public void Run() {
      try {
        Thread.usleep(_timeout);
        if (!_isActive) return;

        _parent.OnExecute();

        if (!_isActive) return;

        Timeout.add (1, () => {
            _parent.OnResult();
            return false;
        });

        _isActive = false;
      } catch (Error e) {
          stderr.printf(e.message);
      }
    }

  public void Start() {
    _isActive = true;
    Run();
  }

  public void Stop() {
    _isActive = false;
  }
}

public class AsyncTaskExecuter : GLib.Object {
  private ThreadPool<AsyncTask> _pool;
  private AsyncTask _task;
  protected int ExecuteTimeout = 300000;  // Timeout before executing

  public virtual void OnExecute() {}
  public virtual void OnResult() {}

  public AsyncTaskExecuter() {
    _pool = new ThreadPool<AsyncTask>.with_owned_data ((worker) => {
      worker.Start ();
    }, 7, false);
  }

  protected void Run() {
    if (_task != null) {
        _task.Stop();
    }
    _task = new AsyncTask(this, ExecuteTimeout);
    _pool.add(_task);
  }
}
