import {
  loadingTab,
  receiveTab,
  getTabDetails,
  cancelCameraAccess,
  activateCamera
} from "../../../reduxs";
const mapStateToProps = store => {
  const { comanda } = store;
  console.log(store);
  return true;
};

const mapDispatchToProps = {
  loadingTab,
  receiveTab,
  getTabDetails,
  cancelCameraAccess,
  activateCamera
};
export const maps = {
  mapStateToProps,
  mapDispatchToProps
};
