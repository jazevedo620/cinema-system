import React from "react";
import PropTypes from "prop-types";
import { isNil, isDefined, capitalize } from "Utility";

import Select from "react-select";

export default class ComboFilter extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  filterValues(row, columnFilter, columnKey) {
    if (isNil(columnFilter.filterTerm)) {
      return true;
    }

    const rawValue = row[columnKey];
    const term = columnFilter.filterTerm.trim().toLowerCase();
    const value = rawValue.trim().toLowerCase();
    return term === "all" || term === value;
  }

  handleChange(value) {
    let newValue = null;
    if (isDefined(value)) {
      if (isDefined(value.value)) {
        newValue = value.value;
      } else {
        newValue = value;
      }
    }
    this.props.onChange({
      filterTerm: newValue,
      column: this.props.column,
      filterValues: this.filterValues
    });
  }

  render() {
    const { column } = this.props;
    const { options, optionsGetter } = column;
    const resolvedOptions = isDefined(options)
      ? options
      : isDefined(optionsGetter)
      ? optionsGetter()
      : [];
    const derivedOptions = resolvedOptions.map(o =>
      typeof o === "string" ? { value: o, label: capitalize(o) } : o
    );

    const inputStyle = {
      width: "100%"
    };

    return (
      <div>
        <div className="form-group">
          <Select
            style={inputStyle}
            classNamePrefix="combo-input"
            className="combo-input"
            options={derivedOptions}
            onChange={this.handleChange}
            menuPortalTarget={document.body}
            menuPosition="fixed"
            menuPlacement="bottom"
            isSearchable
            isClearable
          />
        </div>
      </div>
    );
  }
}

ComboFilter.propTypes = {
  onChange: PropTypes.func.isRequired,
  column: PropTypes.object,
  options: PropTypes.array.isRequired
};
ComboFilter.displayName = "ComboFilter";
