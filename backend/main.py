from flask import Flask, request, jsonify
import yt_dlp
import os

app = Flask(__name__)

@app.route('/get_video_info', methods=['POST'])
def get_video_info():
    video_url = request.form.get('url')
    if not video_url:
        return jsonify({'error': 'No URL provided'}), 400

    ydl_opts = {
        'format': 'best',
        'outtmpl': 'downloads/%(title)s.%(ext)s',
        'quiet': True,
    }

    desired_qualities = ['144p', '240p', '360p', '480p', '720p', '1080p', '2160p']

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info_dict = ydl.extract_info(video_url, download=False)
            title = info_dict.get('title', 'Unknown Title')
            duration = info_dict.get('duration', 0)
            formats = info_dict.get('formats', [])

            qualities = []
            for fmt in formats:
                # Check for a valid height value
                height = fmt.get('height')
                if not height:
                    continue  # Skip formats with no height information

                format_note = fmt.get('format_note', '')
                # Use format_note if it's one of the desired qualities; otherwise, fallback to height-based label
                quality_label = format_note if format_note in desired_qualities else f"{height}p"

                if quality_label in desired_qualities:
                    # Use filesize or filesize_approx; if missing, set as 'Unknown'
                    size = fmt.get('filesize') or fmt.get('filesize_approx')
                    size_val = size if size is not None else 'Unknown'
                    qualities.append({'quality': quality_label, 'size': size_val})

            # Remove duplicates by quality label
            qualities = list({v['quality']: v for v in qualities}.values())

            return jsonify({
                'title': title,
                'duration': duration,
                'qualities': qualities
            })
    
    except yt_dlp.utils.DownloadError as e:
        return jsonify({'error': f"Invalid video URL or unsupported format: {str(e)}"}), 400
    except Exception as e:
        return jsonify({'error': f"Unexpected error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)), threaded=True)
