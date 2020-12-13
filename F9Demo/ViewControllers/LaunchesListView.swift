import SwiftUI

struct LaunchesListView: View {
    @State var launches: [Launch] = []
    
    var body: some View {
        NavigationView {
            List(launches, id: \.id) {
                LaunchRowView(launch: $0)
            }
            .onAppear(perform: loadData)
            .navigationBarTitle("Falcon 9 Launches")
        }
    }
    
    func loadData() {
        LaunchService.fetchData { result in
            DispatchQueue.main.async {
                LoadingOverlays.removeAllBlockingOverlays()
            }
            switch result {
            case .success(let data):
                self.launches = data
            case .failure(let e):
                print(e.rawValue)
            }
        }
    }
}

struct LaunchesListView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchesListView()
    }
}
