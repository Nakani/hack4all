import { getLists } from '../../../reduxs/lists/lists.action';
const mapStateToProps = store => {
  const { lists } = store
  return lists
};

const mapDispatchToProps = {
  getLists,
}
export const maps = {
  mapStateToProps,
  mapDispatchToProps
}
