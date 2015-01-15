// Usage:
// <ProblemTasksForms tasks />
//
// Props:
// - tasks: Array of tasks

(function() {
  window.ProblemTasksForms = React.createClass({
    changeTab: function(tab) {
      this.setState({selectedTab: tab});
    },
    createNewTask: function() {
      var tasks = this.state.tasks;
      tasks.push({"_id": Math.random()});
      this.setState({
        selectedTab: tasks.length - 1,
        tasks: tasks
      });
    },
    deleteTask: function(id) {
      var tasks       = this.state.tasks;
      var selectedTab = this.state.selectedTab;
      if (id === 0 && tasks.length === 1) return; // Doesn't make sense to remove the only task
      tasks.splice(id, 1);
      if (selectedTab >= tasks.length) selectedTab = tasks.length - 1;
      this.setState({
        selectedTab: selectedTab,
        tasks: tasks
      });
    },
    getInitialState: function() {
      var tasks = this.props.tasks;
      if (!tasks || tasks.length === 0) {
        tasks = [{"_id": Math.random()}];
      }

      tasks.sort(function(t1, t2) {
        return (t1.hasOwnProperty("order") ? t1.order : 1e9) - (t2.hasOwnProperty("order") ? t2.order : 1e9);
      });

      return {
        selectedTab: 0,
        tasks: tasks
      };
    },
    render: function() {
      return (
        <div>
          <Tabs tasks={ this.state.tasks }
                selectedTab={ this.state.selectedTab }
                onChangeTab={ this.changeTab }
                onCreateNewTab={ this.createNewTask } />
          <Forms tasks={ this.state.tasks }
                 selectedTab={ this.state.selectedTab }
                 onDeleteTask={ this.deleteTask } />
        </div>
      );
    }
  });

  // Usage:
  // <Tab id selected onClick />
  // Props:
  // - id: The tab ID
  // - selected: boolean
  // - onClick
  Tab = React.createClass({
    onClick: function(e) {
      e.preventDefault();
      this.props.onClick(this.props.id);
    },
    render: function() {
      return (
        <li className={ this.props.selected ? "active" : undefined } onClick={ this.onClick }>
          <a href="#">Case { this.props.id + 1 }</a>
        </li>
      );
    }
  });

  // Usage:
  // <NewTab onClick />
  // Props:
  // - onClick: Create new task
  NewTab = React.createClass({
    render: function() {
      return (
        <li onClick={ this.props.onClick }>
          <a href="#">New</a>
        </li>
      );
    }
  });

  // Usage:
  // <Tabs tasks selectedTab onChangeTab onCreateNewTask />
  // Props:
  // - tasks: Array of tasks
  // - selectedTab: Current active tab
  // - onChangeTab
  // - onCreateNewTab: A function that creates new task when called
  Tabs = React.createClass({
    createNewTab: function(e) {
      e.preventDefault();
      this.props.onCreateNewTab();
    },
    render: function() {
      return (
        <ul className="nav nav-tabs">
          {
            this.props.tasks.map(function(task, i) {
              return (
                <Tab id={ i }
                     selected={ this.props.selectedTab == i}
                     onClick={ this.props.onChangeTab }
                     key={ task.id || task["_id"] } />
              );
            }, this)
          }
          <NewTab onClick={ this.createNewTab } />
        </ul>
      );
    }
  });

  // TODO: Figure out the correct names for each field

  // Usage:
  // <Form task index selected onDeleteTask />
  // Props:
  // - task
  // - index
  // - selected
  // - onDeleteTask
  Form = React.createClass({
    deleteTask: function(e) {
      e.preventDefault();
      this.props.onDeleteTask(this.props.index);
    },
    getElementName: function(attribute) {
      return "problem[tasks_attributes][" + this.props.index + "][" + attribute + "]";
    },
    render: function() {
      return (
        <div className={ "tab-pane tasks-forms" + (this.props.selected ? " active" : "")}>
          {
            !this.props.task.id &&
              <button type="button" className="close" onClick={ this.deleteTask }>
                <span aria-hidden="true">&times;</span>
                <span className="sr-only">Close</span>
              </button>
          }

          {
            !!this.props.task.id &&
              <input type="hidden"
                     value={ this.props.task.id }
                     name={ this.getElementName("id") } />
          }

          <input type="hidden"
                 value={ this.props.index }
                 name={ this.getElementName("order") } />

          <div className="form-group">
            <label>Point</label>
            <input type="number"
                   name={ this.getElementName("point") }
                   className="form-control"
                   defaultValue={ this.props.task.point } />
          </div>

          <div className="form-group">
            <label>Tokens</label>
            <input type="number"
                   name={ this.getElementName("tokens") }
                   className="form-control"
                   defaultValue={ this.props.task.tokens } />
          </div>

          <div className="form-group">
            <label>Label</label>
            <input type="text"
                   name={ this.getElementName("label") }
                   className="form-control"
                   defaultValue={ this.props.task.label } />
          </div>

          <div className="form-group">
            <label>Input generator</label>
            <p className="help-block">
              Please make sure the generator completes its execution in 1 second.
            </p>
            <AceEditor language="ruby"
                       tabSize={ 2 }
                       name={ this.getElementName("input_generator") }
                       value={ this.props.task.input_generator } />
          </div>

          <div className="form-group">
            <label>Grader</label>
            <AceEditor language="ruby"
                       tabSize={ 2 }
                       name={ this.getElementName("grader") }
                       value={ this.props.task.grader } />
          </div>

          {
            !!this.props.task.id &&
              <div className="checkbox">
                <label>
                  <input type="checkbox"
                    name={ this.getElementName("_destroy") } />
                  Delete
                </label>
              </div>
          }
        </div>
      );
    }
  });

  // Usage:
  // <Forms tasks selectedTab onDeleteTask />
  // Props:
  // - tasks: Array of tasks
  // - selectedTab: Current active tab
  // - onDeleteTask
  Forms = React.createClass({
    render: function() {
      return (
        <div className="tab-content">
          {
            this.props.tasks.map(function(task, i) {
              return (
                <Form task={ task }
                      selected={i == this.props.selectedTab }
                      index={ i }
                      onDeleteTask={ this.props.onDeleteTask }
                      key={ task.hasOwnProperty("id") ? task.id : task["_id"] } />
              );
            }, this)
          }
        </div>
      );
    }
  });
})();
