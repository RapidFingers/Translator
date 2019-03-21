/// For executing task on thread
private class AsyncTask : GLib.Object {
  private bool _isActive;
  private int _timeout;
  private AsyncTaskExecuter _parent;

  /// Constructor
  public AsyncTask(AsyncTaskExecuter parent, int timeout) {
    _parent = parent;
    _timeout = timeout;
  }

  /// Execute on thread
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
      }
      catch(TranslatorError e) {
        _parent.OnError(e);
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

/// Executer of AsyncTask
public class AsyncTaskExecuter : GLib.Object {
  /// Thread pool
  private ThreadPool<AsyncTask> _pool;

  /// Async task to execute
  private AsyncTask _task;

  /// Timeout of execution
  protected int ExecuteTimeout = 300000;  // Timeout before executing

  /// On error signal
  public signal void error(TranslatorError error);

  /// Main working method
  public virtual void OnExecute() throws TranslatorError {}

  /// On work result
  public virtual void OnResult() {}

  /// On error
  public void OnError(TranslatorError err) {
    error(err);
  }

  /// Constructor
  public AsyncTaskExecuter() {
    try {
      _pool = new ThreadPool<AsyncTask>.with_owned_data ((worker) => {
        worker.Start ();
      }, 7, false);
    }
    catch (GLib.ThreadError error) {
          warning ("%s", error.message);
      }
  }

  /// Run task
  protected void Run() {
    if (_task != null) {
        _task.Stop();
    }
      _task = new AsyncTask(this, ExecuteTimeout);
    try {
      _pool.add(_task);
    }
    catch (GLib.ThreadError error) {
        warning ("%s", error.message);
      }
  }
}
