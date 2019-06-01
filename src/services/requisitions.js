import axios from "axios";

const config = {
  headers: {
    "Content-Type": "application/json"
  }
};

async function getListsAll() {
  try {
    const response = await axios.get(`http://dev.4all.com:3003/tarefa`, config);
    const listArray = [];
    axios.all(
      response.data.lista.map(function(result) {
        new Promise((resolve, reject) => {
          fetch("http://dev.4all.com:3003/tarefa/" + result)
            .then(response => {
              resolve(response.json().then(data => data));
            })
            .catch(response => {
              reject("Api call failed!" + response);
            });
        })
          .then(response => {
            listArray.push({
              response
            });
          })
          .catch(response => {
            console.log("error: " + response);
          });
      })
    );

    return listArray;
  } catch (error) {
    console.log(error);
  }
}

async function getDetailList(id) {
  try {
    const response = await axios.get(
      `http://dev.4all.com:3003/tarefa/${id}`,
      config
    );
    return response.data;
  } catch (error) {
    console.log("ops deu erro", error);
    console.error(error);
  }
}

export const requisitionsService = {
  getListsAll,
  getDetailList
};
