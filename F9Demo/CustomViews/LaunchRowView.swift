import SwiftUI

struct LaunchRowView: View {
    var launch: Launch
    
    private var successImage: String {
        guard let missionStatus = launch.success else {
            return "ic_unknown"
        }

        return missionStatus ? "ic_success" : "ic_failed"
    }
    
    private var formattedLaunchDate: String {
        return launch.date.toDate("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").toString("MM-dd-yyyy")
    }
    
    var body: some View {
        HStack(spacing: 10) {
            RemoteImageView(urlString: launch.links?.patch?.small)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(launch.name)")
                    .font(.headline)
                Text("Launch Date: \(formattedLaunchDate)")
                    .font(.subheadline)
                
                HStack(alignment: .center, spacing: 4) {
                    Text("Mission Success:")
                        .font(.subheadline)
                    Image(successImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Spacer()
                }
            }
        }
    }
}

struct LaunchRowView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchRowView(launch: Launch(id: 1, name: "ABC", date: "2020-12-12T02:50:12.208Z", success: true, links: nil))
    }
}
