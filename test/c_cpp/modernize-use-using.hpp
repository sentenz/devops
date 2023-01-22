#ifndef MODERNIZE_USE_USING_HPP

#define MODERNIZE_USE_USING_HPP


namespace tidy {


template <class Iterator>
struct iterator_traits
{
    using iterator_category = typename Iterator::category;
    using value_type = typename Iterator::value_type;
    using difference_type = typename Iterator::difference_type;
    using pointer = typename Iterator::pointer;
    using reference = typename Iterator::reference;
};

template <class InputIterator, class Distance>
void advance(InputIterator&, Distance)
{
    typename iterator_traits<InputIterator>::iterator_category category;
}

} // namespace tidy

#endif
