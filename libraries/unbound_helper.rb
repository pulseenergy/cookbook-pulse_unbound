# Copyright 2016 EnerNOC, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module UnboundHelper
  # The syntax of the Unbound configuration file (unbound.conf) does not map cleanly onto simple nested Hashes. Instead, it is
  # possible for items to occur more than once in a clause, and in those cases the key should be repeated.

  # We NEED a reference to the element's parent to render it
  # A hash can't be rendered on its own, it needs to know the array that contained it
  def render_unbound_configfile(element, parent=nil, indent=0)
    if element.is_a?(Hash) && parent == nil
      element.map { |k,v| render_unbound_configfile(v, k) }.join("\n\n") + "\n"
    elsif element.is_a?(Hash)
      [
        " "*indent + "#{parent}:",
        element.map { |k,v| render_unbound_configfile(v, k, indent+2) }
      ].join("\n")
    elsif element.is_a?(Array)
      element.map { |e|
        # Arrays of scalars are okay, and arrays of hashes are okay. Arrays of arrays are NOT OKAY. I think.
        render_unbound_configfile(e, parent, indent)
      }.join("\n")
    else
      " "*indent + "#{parent.to_s}: #{stringify_value(element)}"
    end
  end

  def stringify_value(value)
    if [true, false].include?(value)
      value ? 'yes' : 'no'
    elsif value.is_a?(Fixnum)
      value.to_s
    else
      if value.to_s.include?('"')
        value.to_s
      else
        "\"#{value.to_s}\""
      end
    end
  end

end
