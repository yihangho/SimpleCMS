// Usage:
// <AceEditor />
//
// Optional props:
// - language
// - tabSize
// - name
//
// If name is set, then a hidden element with that name will be created to
// mirror the current value of the editor.

(function() {
  window.AceEditor = React.createClass({
    getInitialState: function() {
      return {
        value: ""
      };
    },
    componentDidMount: function() {
      var editor = ace.edit(this.refs.editor.getDOMNode());
      editor.setTheme("ace/theme/monokai");
      if (this.props.hasOwnProperty("language")) {
        editor.getSession().setMode("ace/mode/" + this.props.language);
      }
      if (this.props.hasOwnProperty("tabSize")) {
        editor.getSession().setTabSize(this.props.tabSize);
      }

      editor.getSession().on('change', function() {
        this.setState({
          value: editor.getValue()
        })
      }.bind(this));
    },
    render: function() {
      var hiddenInput = false;
      if (this.props.hasOwnProperty("name")) {
        hiddenInput = (
          <input type="hidden" name={ this.props.name } value={ this.state.value } />
        );
      }

      return (
        <div>
          <div ref="editor" />
          { hiddenInput }
        </div>
      );
    }
  });
})();
