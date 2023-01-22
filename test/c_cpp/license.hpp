// Copyright [yyyy] [name of copyright owner]
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

#ifndef MODERNIZE_USE_USING_HPP

#define MODERNIZE_USE_USING_HPP

namespace tidy {

  template<class Iterator>
  struct iterator_traits {
    using iterator_category = typename Iterator::category;
    using value_type        = typename Iterator::value_type;
    using difference_type   = typename Iterator::difference_type;
    using pointer           = typename Iterator::pointer;
    using reference         = typename Iterator::reference;
  };

  template<class InputIterator, class Distance>
  void advance(InputIterator&, Distance) {
    typename iterator_traits<InputIterator>::iterator_category category;
  }

}  // namespace tidy

#endif
