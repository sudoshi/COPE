import SwiftUI

/// Multi-select tag pill (stress/triggers, feeling words, intake concerns).
public struct ChoiceChip: View {
    private let label: String
    private let isSelected: Bool
    private let action: () -> Void

    public init(_ label: String, isSelected: Bool, action: @escaping () -> Void) {
        self.label = label
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(label)
                .font(CopeFont.figtree(12, .semibold))
                .foregroundStyle(isSelected ? .white : CopeColor.ink2)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(isSelected ? CopeColor.teal : CopeColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: CopeRadius.chip, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CopeRadius.chip, style: .continuous)
                        .strokeBorder(isSelected ? CopeColor.teal : CopeColor.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// 2–3 equal pills, single selection (sleep quality, structured replies).
public struct SegmentedChoice<Value: Hashable>: View {
    private let options: [(value: Value, label: String)]
    @Binding private var selection: Value?

    public init(_ options: [(Value, String)], selection: Binding<Value?>) {
        self.options = options.map { (value: $0.0, label: $0.1) }
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.value) { option in
                let active = selection == option.value
                Button {
                    selection = option.value
                } label: {
                    Text(option.label)
                        .font(CopeFont.figtree(13, .semibold))
                        .foregroundStyle(active ? .white : CopeColor.ink2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(active ? CopeColor.teal : CopeColor.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: CopeRadius.pill, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: CopeRadius.pill, style: .continuous)
                                .strokeBorder(active ? CopeColor.teal : CopeColor.line, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(active ? .isSelected : [])
            }
        }
    }
}

/// Full-width left-aligned option with title + optional subtitle (mania pole,
/// C-SSRS, PHQ answers).
public struct StackedOption: View {
    private let title: String
    private let subtitle: String?
    private let isSelected: Bool
    private let action: () -> Void

    public init(_ title: String, subtitle: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(CopeFont.figtree(14.5, .semibold))
                    .foregroundStyle(CopeColor.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(CopeFont.caption)
                        .foregroundStyle(CopeColor.ink2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(isSelected ? CopeColor.tealSoft : CopeColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? CopeColor.teal : CopeColor.line, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
